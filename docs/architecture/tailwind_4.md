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

## Host Application Configuration

### 1. Install tailwindcss-rails Gem

```ruby
# Gemfile
gem 'tailwindcss-rails', '~> 3.0'
```

Then run:

```bash
bundle install
```

### 2. Set Up Application CSS

Create or update `app/assets/stylesheets/application.css`:

```css
/* app/assets/stylesheets/application.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Import FlatPack CSS Variables */
:root {
  /* Copy CSS variables from FlatPack's variables.css */
  /* Or include them inline as shown in the example below */
  --color-primary: oklch(0.52 0.26 250);
  /* ... other variables */
}
```

### 3. Configure Tailwind Content Scanning

Create `config/tailwind.config.js`:

```javascript
module.exports = {
  content: [
    './app/views/**/*.{erb,haml,html,slim}',
    './app/components/**/*.{rb,erb,haml,html,slim}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    // Scan FlatPack components
    './vendor/bundle/ruby/*/gems/flat_pack-*/app/components/**/*.{rb,erb}',
  ],
  theme: {
    extend: {},
  },
  plugins: []
}
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
  label: "Custom",
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

1. **Check @source paths:**
   ```bash
   bundle info flat_pack
   # Verify path matches @source comment
   ```

2. **Restart Tailwind:**
   Tailwind needs to detect new sources.

3. **Check for typos:**
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

## Migration from Tailwind v3

If migrating from v3:

1. **Remove `tailwind.config.js`** - Not needed
2. **Convert config to `@theme`** - Move to CSS
3. **Update content paths** - Use `@source` comments
4. **Test dark mode** - May need adjustments
5. **Update plugins** - Check v4 compatibility

## Resources

- [Tailwind CSS 4 Docs](https://tailwindcss.com/blog/tailwindcss-v4-alpha)
- [OKLCH Color Picker](https://oklch.com/)
- [CSS @theme MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/@theme)

## Next Steps

- [Theming Guide](../theming.md)
- [Dark Mode Guide](../dark_mode.md)
- [Asset Pipeline](assets.md)
