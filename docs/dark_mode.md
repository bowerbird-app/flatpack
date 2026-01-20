# Dark Mode Guide

FlatPack implements dark mode using system preferences only (`prefers-color-scheme`). There is no manual toggle.

## Philosophy

FlatPack's dark mode approach:
- **System-driven only** - Respects OS/browser preference
- **No manual toggle** - Reduces complexity and state management
- **Automatic switching** - Changes instantly when system preference changes
- **Consistent behavior** - All components respect system preference

## How It Works

FlatPack uses CSS media queries to detect system preference:

```css
/* Light mode (default) */
@theme {
  --color-background: oklch(1.0 0 0); /* White */
  --color-foreground: oklch(0.20 0.01 250); /* Dark gray */
}

/* Dark mode (system preference) */
@media (prefers-color-scheme: dark) {
  @theme {
    --color-background: oklch(0.15 0.01 250); /* Dark */
    --color-foreground: oklch(0.95 0.01 250); /* Light */
  }
}
```

## Testing Dark Mode

### macOS
1. System Preferences → General → Appearance
2. Select "Dark"

### Windows
1. Settings → Personalization → Colors
2. Choose "Dark" under "Choose your color"

### Linux (GNOME)
1. Settings → Appearance
2. Select "Dark"

### Browser DevTools
Chrome/Edge/Firefox:
1. Open DevTools (F12)
2. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
3. Type "Render"
4. Select "Show Rendering"
5. Find "Emulate CSS media feature prefers-color-scheme"
6. Select "prefers-color-scheme: dark"

## Customizing Dark Mode

Override dark mode colors in your `application.css`:

```css
@import "flat_pack/variables.css";

/* Custom dark mode colors */
@media (prefers-color-scheme: dark) {
  @theme {
    --color-primary: oklch(0.70 0.25 270); /* Lighter purple for dark bg */
    --color-background: oklch(0.10 0.02 250); /* Darker background */
    --color-foreground: oklch(0.98 0.01 250); /* Brighter text */
  }
}
```

## Complete Dark Mode Example

```css
@theme {
  /* Light mode */
  --color-primary: oklch(0.55 0.25 230);
  --color-background: oklch(1.0 0 0);
  --color-foreground: oklch(0.15 0.01 230);
  --color-border: oklch(0.85 0.02 230);
}

@media (prefers-color-scheme: dark) {
  @theme {
    /* Dark mode - adjust lightness and chroma */
    --color-primary: oklch(0.65 0.22 230); /* Lighter, less saturated */
    --color-background: oklch(0.12 0.01 230); /* Very dark */
    --color-foreground: oklch(0.95 0.01 230); /* Very light */
    --color-border: oklch(0.25 0.02 230); /* Subtle border */
  }
}
```

## Dark Mode Considerations

### Contrast
- Ensure sufficient contrast in both modes (WCAG AA: 4.5:1)
- Test all button schemes in dark mode
- Check border visibility

### Shadows
- Shadows are more pronounced in light mode
- FlatPack adjusts shadow opacity automatically
- Override `--shadow-*` variables if needed

### Images and Icons
- Consider providing dark variants of logos
- Use CSS `filter: invert()` for simple icons
- SVGs with `currentColor` adapt automatically

### Colors
- Reduce chroma (saturation) in dark mode for comfort
- Increase lightness for foreground colors
- Decrease lightness for background colors

## Why No Manual Toggle?

FlatPack intentionally doesn't provide a manual dark mode toggle:

### Advantages
1. **Simplicity** - No state management, no storage, no hydration issues
2. **Consistency** - Matches user's OS preference across all apps
3. **Accessibility** - Respects system-wide accessibility settings
4. **Performance** - No JavaScript required
5. **Privacy** - No preference tracking

### When You Need Manual Toggle

If your application requires manual dark mode toggle:

1. Implement it in your application (not the component library)
2. Use a class-based approach (e.g., `.dark` on `<html>`)
3. Override FlatPack variables within that class:

```css
/* Your application's manual dark mode */
.dark {
  @theme {
    --color-background: oklch(0.15 0.01 250);
    --color-foreground: oklch(0.95 0.01 250);
    /* ... etc */
  }
}
```

Then manage the `.dark` class with JavaScript:

```javascript
// Your application code
document.documentElement.classList.toggle('dark')
```

## Testing Checklist

- [ ] All buttons visible in both modes
- [ ] Tables have sufficient contrast
- [ ] Borders visible in both modes
- [ ] Focus rings visible
- [ ] Hover states work correctly
- [ ] Text is readable
- [ ] Icons are visible

## Browser Support

Dark mode via `prefers-color-scheme` is supported in:
- Chrome 76+
- Firefox 67+
- Safari 12.1+
- Edge 79+

## Troubleshooting

### Dark mode not activating
1. Check system preference is set to dark
2. Check browser supports `prefers-color-scheme`
3. Clear browser cache
4. Restart Rails server

### Colors look wrong in dark mode
1. Verify your custom colors are in the media query
2. Check OKLCH values (L should be higher for foreground, lower for background)
3. Test in actual dark mode, not DevTools emulation

### Flash of wrong theme on page load
This doesn't occur with system preference approach (no JavaScript).

## Resources

- [MDN: prefers-color-scheme](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme)
- [Web.dev: prefers-color-scheme](https://web.dev/prefers-color-scheme/)
- [Contrast Checker](https://webaim.org/resources/contrastchecker/)

## Next Steps

- [Theming Guide](theming.md)
- [Component Documentation](components/)
