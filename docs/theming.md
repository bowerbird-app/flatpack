# Theming Guide

FlatPack uses CSS variables for theming, allowing you to customize the appearance without modifying component code.

If you want a complete copy-pasteable custom theme with every current FlatPack variable, use the [Custom Theming Guide](custom_theming.md).

## Overview

FlatPack's theming system is built on:
- Tailwind CSS 4's `@theme` directive
- CSS custom properties (variables)
- OKLCH color space for perceptual uniformity
- Default `:root` variables plus optional `data-theme` variant overrides

## Basic Customization

FlatPack variables are loaded automatically via `stylesheet_link_tag` in your layout (added by the install generator). To override them, add a `:root` block to your `application.css`:

```css
/* app/assets/stylesheets/application.css */

/* Your custom theme */
:root {
  --color-primary: oklch(0.55 0.25 270); /* Purple */
  --color-primary-hover: oklch(0.45 0.28 270);
}
```

For a named host-app variant such as `[data-theme="sunrise"]`, including a complete starter template you can rename, see the [Custom Theming Guide](custom_theming.md).

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

--color-success-background-color
--color-success-hover-background-color
--color-success-text
--color-success-border

--color-warning-background-color
--color-warning-hover-background-color
--color-warning-text
--color-warning-border

--color-danger-background-color
--color-danger-hover-background-color
--color-danger-text-color
--color-danger-border-color

--surface-background-color
--surface-page-background-color
--surface-content-color

--surface-muted-background-color
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
--stack-gap-sm: 0.5rem
--stack-gap-md: 1rem
--stack-gap-lg: 1.5rem
```

Use stack gap tokens on parent layout containers (for example, form stacks) to control spacing between components.

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
- Colors: `--surface-content-color`, `--surface-background-color`, `--surface-muted-content-color`, `--surface-border-color`, `--color-ring`, `--color-warning-border`
- Radius: `--radius-md`
- Transition: `--transition-base`

### Checkbox
- Colors: `--surface-background-color`, `--surface-border-color`, `--color-primary`, `--color-ring`
- Size: `--checkbox-size`
- Radius: `--checkbox-radius`
- Label spacing: `--checkbox-label-gap`

### Table
- Colors: `--surface-border-color`, `--surface-muted-background-color`
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

## Theme Variants

FlatPack ships a default light palette and can be customized per variant by overriding variables under `data-theme` selectors:

```css
[data-theme="dark"] {
  --color-primary: oklch(0.65 0.25 270);
  --color-primary-hover: oklch(0.75 0.22 270);
  /* Adjust other colors for the dark variant */
}
```

If you use the optional theme controller, `system` mode maps the current OS preference to either the default light palette or `data-theme="dark"`.

See the [Custom Theming Guide](custom_theming.md) for a complete starter block and the [Dark Mode Guide](dark_mode.md) for runtime switching details.

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
- Ensure your `application.css` is linked in the layout **after** the FlatPack stylesheet link tags so overrides take precedence
- Restart your Rails server
- Clear your browser cache

### Dark mode not working
- Check whether `<html>` has the expected `data-theme` value
- If you use the theme controller, inspect `localStorage.getItem("flatpack-theme")`
- See [Dark Mode Guide](dark_mode.md)

## Next Steps

- [Dark Mode Guide](dark_mode.md)
- [Component Documentation](components/)
- [Architecture: Tailwind 4](architecture/tailwind_4.md)
