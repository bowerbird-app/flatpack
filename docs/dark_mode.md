# Dark Mode Guide

FlatPack ships a light theme by default and supports dark or custom theme variants through CSS variables and `data-theme` selectors.

## Overview

FlatPack theme behavior is split into two layers:

- **CSS defaults** - `:root {}` in `flat_pack/variables.css` provides the default light palette.
- **Theme variants** - selectors such as `[data-theme="dark"]`, `[data-theme="ocean"]`, and `[data-theme="rounded"]` override those variables.
- **Optional controller support** - the `flat-pack--theme` Stimulus controller can switch between `system`, `light`, `dark`, and custom variants while persisting the choice in `localStorage` under `flatpack-theme`.

## How It Works

If no theme attribute is present, FlatPack stays on the default light palette.

```html
<html lang="en">
```

To force a built-in variant, set `data-theme` on the root element:

```html
<html data-theme="dark" lang="en">
```

Supported built-in values documented by the install guide are:

- `light` - same as omitting the attribute
- `dark`
- `ocean`
- `rounded`

## System Mode

When you use the optional `flat-pack--theme` controller, selecting `system` checks `prefers-color-scheme: dark` and then either:

- removes `data-theme` for the light palette, or
- sets `data-theme="dark"` when the OS prefers dark mode

That controller also keeps `dark` and `light` classes in sync on `<html>` for legacy selectors.

## Customizing Dark Theme Tokens

Override FlatPack variables in your application stylesheet after the FlatPack link tags have loaded:

```css
/* app/assets/stylesheets/application.css */

[data-theme="dark"] {
  --color-primary: oklch(0.70 0.20 250);
  --color-primary-hover: oklch(0.64 0.18 250);
  --surface-background-color: oklch(0.18 0.01 250);
  --surface-content-color: oklch(0.95 0.01 250);
  --surface-border-color: oklch(0.30 0.02 250);
}
```

You can define additional custom themes the same way:

```css
[data-theme="forest"] {
  --color-primary: oklch(0.58 0.18 155);
  --surface-background-color: oklch(0.98 0.01 150);
}
```

## Testing Themes

### Explicit theme variants

Set the root attribute in the browser console:

```javascript
document.documentElement.setAttribute("data-theme", "dark")
```

Reset to the default light palette:

```javascript
document.documentElement.removeAttribute("data-theme")
```

### System mode

When testing `system` mode, use your browser's `prefers-color-scheme` emulation and verify that the theme controller updates the root attribute as expected.

## Troubleshooting

### Dark theme not appearing

1. Confirm `flat_pack/variables` is linked in your layout.
2. Check whether `<html>` has the expected `data-theme` attribute.
3. If you use the theme controller, inspect `localStorage.getItem("flatpack-theme")`.

### Wrong colors after overriding

1. Make sure your stylesheet loads after FlatPack's stylesheet tags.
2. Override concrete variable values, not self-referential mappings such as `--radius-md: var(--radius-md)`.
3. Verify your selector matches the active theme, for example `[data-theme="dark"]`.

### Flash of the light theme

If you rely on the optional JS controller to restore a saved theme, the page may paint the default light palette before JavaScript runs. To avoid that, render the expected `data-theme` attribute server-side.

## Next Steps

- [Theming Guide](theming.md)
- [Installation Guide](installation.md)
- [Architecture: Tailwind 4](architecture/tailwind_4.md)
