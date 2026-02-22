# Theming Guide

FlatPack uses CSS variables for theming, allowing you to customize the appearance without modifying component code.

## Overview

FlatPack's theming system is built on:
- Tailwind CSS 4's `@theme` directive
- CSS custom properties (variables)
- OKLCH color space for perceptual uniformity
- System preference detection for dark mode

## Basic Customization

Override FlatPack's CSS variables in your `application.css`:

```css
@import "tailwindcss";
@import "flat_pack/variables.css";

/* Your custom theme */
@theme {
  --color-primary: oklch(0.55 0.25 270); /* Purple */
  --color-primary-hover: oklch(0.45 0.28 270);
}
```

## Available Variables

### Color Variables

#### Brand Colors
```css
--color-brand-50 through --color-brand-950
```

A complete scale of brand colors from lightest to darkest.

#### Semantic Colors
```css
--color-default
--color-default-hover
--color-default-text
--color-default-border

--color-primary
--color-primary-hover
--color-primary-text

--color-secondary
--color-secondary-hover
--color-secondary-text

--color-ghost
--color-ghost-hover
--color-ghost-text

--color-success-bg
--color-success-bg-hover
--color-success-text
--color-success-border

--color-warning-bg
--color-warning-bg-hover
--color-warning-text
--color-warning-border

--color-destructive-bg
--color-destructive-bg-hover
--color-destructive-text
--color-destructive-border

--surface-bg-color
--surface-page-bg-color
--surface-content-color

--surface-muted-bg-color
--surface-muted-content-color

--surface-border-color
--surface-border-hover-color

--gradient-1
--gradient-2
--gradient-3
--gradient-4

--color-ring
```

### Spacing Variables
```css
--spacing-xs: 0.25rem
--spacing-sm: 0.5rem
--spacing-md: 1rem
--spacing-lg: 1.5rem
--spacing-xl: 2rem
```

### Border Radius
```css
--radius-sm: 0.25rem
--radius-md: 0.375rem
--radius-lg: 0.5rem
--radius-xl: 0.75rem
```

### Shadows
```css
--shadow-sm
--shadow-md
--shadow-lg
```

### Transitions
```css
--transition-fast: 150ms
--transition-base: 200ms
--transition-slow: 300ms
```

## Component Variable Usage

### Buttons
- Colors: `--color-default-*`, `--color-primary-*`, `--color-secondary-*`, `--color-ghost-*`, `--color-success-*`, `--color-warning-*`
- Radius: `--radius-md`
- Shadow: `--shadow-sm`
- Transition: `--transition-base`

### Input Components (Text, Email, Password, Phone, Search, URL, TextArea)
- Colors: `--surface-content-color`, `--surface-bg-color`, `--surface-muted-content-color`, `--surface-border-color`, `--color-ring`, `--color-warning-border`
- Radius: `--radius-md`
- Transition: `--transition-base`

### Table
- Colors: `--surface-border-color`, `--surface-muted-bg-color`
- Radius: `--radius-lg`
- Transition: `--transition-fast`

### Button Group & Segmented Buttons
- Inherits from button variables
- Shadow: `--shadow-sm`
- Radius: `--radius-md`

## Complete Theme Example

```css
@theme {
  /* Brand Colors - Custom Purple Theme */
  --color-brand-500: oklch(0.65 0.25 270);
  --color-brand-600: oklch(0.55 0.25 270);
  --color-brand-700: oklch(0.45 0.28 270);
  
  /* Semantic Colors */
  --color-primary: var(--color-brand-600);
  --color-primary-hover: var(--color-brand-700);
  
  /* Custom border radius for rounded look */
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;
  
  /* Faster transitions */
  --transition-base: 150ms;
}
```

## Dark Mode Theme

Dark mode variables are defined within a `@media (prefers-color-scheme: dark)` query:

```css
@media (prefers-color-scheme: dark) {
  @theme {
    --color-primary: oklch(0.65 0.25 270);
    --color-primary-hover: oklch(0.75 0.22 270);
    /* Adjust other colors for dark mode */
  }
}
```

See [Dark Mode Guide](dark_mode.md) for details.

## Using OKLCH Colors

FlatPack uses OKLCH color space for better perceptual uniformity:

```
oklch(L C H)
  L = Lightness (0-1)
  C = Chroma (0-0.4)
  H = Hue (0-360)
```

### Examples:
```css
/* Blue */
oklch(0.62 0.22 250)

/* Green */
oklch(0.62 0.22 150)

/* Red */
oklch(0.62 0.22 30)

/* Purple */
oklch(0.62 0.22 300)
```

### Benefits:
- Perceptually uniform lightness
- Consistent chroma across hues
- Better than HSL for theming
- Wider color gamut

## Theme Presets

### Corporate Theme
```css
@theme {
  --color-primary: oklch(0.45 0.15 230); /* Navy blue */
  --color-secondary: oklch(0.85 0.05 230);
  --radius-md: 0.25rem; /* Sharp corners */
}
```

### Playful Theme
```css
@theme {
  --color-primary: oklch(0.65 0.30 330); /* Hot pink */
  --color-secondary: oklch(0.75 0.25 60); /* Yellow */
  --radius-md: 0.75rem; /* Very rounded */
}
```

### Minimal Theme
```css
@theme {
  --color-primary: oklch(0.20 0.02 250); /* Near black */
  --color-secondary: oklch(0.95 0.01 250); /* Near white */
  --radius-md: 0rem; /* No rounding */
}
```

## Component-Specific Customization

Some components can be customized via the `class` system argument:

```erb
<%= render FlatPack::Button::Component.new(
  text: "Custom",
  class: "!bg-gradient-to-r from-purple-500 to-pink-500"
) %>
```

The `!` prefix ensures your classes override component defaults (via TailwindMerge).

## Best Practices

1. **Define variables, don't override classes** - Use CSS variables instead of overriding Tailwind classes
2. **Test in both light and dark mode** - Ensure your theme works in both
3. **Maintain contrast ratios** - Ensure accessibility (WCAG AA: 4.5:1 for text)
4. **Use the full color scale** - Define all brand colors (50-950) for consistency
5. **Keep semantic colors semantic** - Don't use `--color-primary` for errors

## Tools

- [OKLCH Color Picker](https://oklch.com/)
- [Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Color Scale Generator](https://uicolors.app/create)

## Troubleshooting

### Colors not applying
- Ensure your `@theme` block comes after `@import "flat_pack/variables.css"`
- Restart your Rails server
- Clear your browser cache

### Dark mode not working
- Check system preference is set to dark mode
- See [Dark Mode Guide](dark_mode.md)

## Next Steps

- [Dark Mode Guide](dark_mode.md)
- [Component Documentation](components/)
- [Architecture: Tailwind 4](architecture/tailwind_4.md)
