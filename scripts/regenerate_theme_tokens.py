#!/usr/bin/env python3
"""Regenerate variables.css: brand primitives, semantic remaps, slim theme overrides."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "app/assets/stylesheets/flat_pack/variables.css"
# Prefer original backup if regenerating from already-slimmed file is unsafe.
# This script expects a FULL original (all themes fully expanded) as input.

def extract_block(css, start_pat):
    m = re.search(start_pat, css)
    if not m:
        raise RuntimeError(f"missing block: {start_pat}")
    brace = css.index("{", m.start())
    depth = 0
    i = brace
    while i < len(css):
        if css[i] == "{":
            depth += 1
        elif css[i] == "}":
            depth -= 1
            if depth == 0:
                break
        i += 1
    body = css[brace + 1 : i]
    order, values = [], {}
    for name, val in re.findall(r"(--[a-z0-9-]+)\s*:\s*([^;]+);", body, flags=re.I):
        key = name.lower()
        if key not in values:
            order.append(key)
        values[key] = val.strip()
    return order, values, m.start(), i

EXPLICIT_REMAPS = {
    "--sidebar-item-active-background-color": "var(--color-primary)",
    "--sidebar-item-active-text-color": "var(--color-primary-text)",
    "--sidebar-item-active-icon-color": "var(--color-primary-text)",
    "--top-nav-item-active-background-color": "var(--color-primary)",
    "--top-nav-item-active-text-color": "var(--color-primary-text)",
    "--top-nav-item-active-icon-color": "var(--color-primary-text)",
    "--sidebar-border-color": "var(--surface-border-color)",
    "--sidebar-divider-color": "var(--surface-border-color)",
    "--sidebar-item-text-color": "var(--surface-muted-content-color)",
    "--sidebar-item-icon-color": "var(--surface-muted-content-color)",
    "--sidebar-item-hover-background-color": "var(--surface-muted-background-color)",
    "--sidebar-item-hover-text-color": "var(--surface-content-color)",
    "--sidebar-footer-text-color": "var(--surface-muted-content-color)",
    "--sidebar-background-color": "var(--surface-background-color)",
    "--top-nav-background-color": "var(--surface-background-color)",
    "--top-nav-item-text-color": "var(--surface-muted-content-color)",
    "--top-nav-item-icon-color": "var(--surface-muted-content-color)",
    "--top-nav-item-hover-background-color": "var(--surface-muted-background-color)",
    "--top-nav-item-hover-text-color": "var(--surface-content-color)",
}
BRAND_INSERT = [("--brand-hue", "250"), ("--brand-chroma", "0.26")]
BRAND_OVERRIDES = {
    "--color-primary": "oklch(0.52 var(--brand-chroma) var(--brand-hue))",
    "--color-primary-hover": "oklch(0.42 calc(var(--brand-chroma) - 0.02) var(--brand-hue))",
    "--color-ring": "var(--color-primary)",
    "--surface-content-color": "oklch(0.20 0.01 var(--brand-hue))",
    "--surface-muted-background-color": "oklch(0.96 0.01 var(--brand-hue))",
    "--surface-muted-content-color": "oklch(0.45 0.01 var(--brand-hue))",
    "--surface-border-color": "oklch(0.89 0.01 var(--brand-hue))",
    "--surface-border-hover-color": "oklch(0.82 0.02 var(--brand-hue))",
    "--color-secondary": "oklch(0.95 0.01 var(--brand-hue))",
    "--color-secondary-hover": "oklch(0.90 0.02 var(--brand-hue))",
    "--color-secondary-text": "oklch(0.25 0.02 var(--brand-hue))",
    "--color-ghost-hover": "oklch(0.96 0.01 var(--brand-hue))",
    "--color-ghost-text": "oklch(0.35 0.02 var(--brand-hue))",
}
NEW_TOKENS = [
    ("--surface-subtle-background-color", "var(--surface-muted-background-color)"),
    ("--transition-fast", "var(--duration-fast)"),
    ("--transition-base", "var(--duration-base)"),
    ("--transition-slow", "var(--duration-slow)"),
    ("--tabs-pill-list-border-color", "var(--surface-border-color)"),
    ("--tabs-stacked-pill-list-background-color", "var(--surface-muted-background-color)"),
]

def expand_brand(val):
    out = val.replace("var(--brand-hue)", "250").replace("var(--brand-chroma)", "0.26")
    out = out.replace("calc(0.26 - 0.02)", "0.24")
    return out

def apply_base(order, values):
    values = dict(values)
    order = list(order)
    for k, v in reversed(BRAND_INSERT):
        values[k] = v
        if k in order:
            order.remove(k)
        order.insert(0, k)
    for k, v in BRAND_OVERRIDES.items():
        if k in values:
            values[k] = v
    for k, v in EXPLICIT_REMAPS.items():
        if k in values:
            values[k] = v
    for k, v in NEW_TOKENS:
        values[k] = v
        if k not in order:
            if k.startswith("--surface-subtle"):
                idx = order.index("--surface-muted-background-color") + 1 if "--surface-muted-background-color" in order else len(order)
            elif k.startswith("--transition-"):
                idx = order.index("--duration-slow") + 1 if "--duration-slow" in order else len(order)
            elif k.startswith("--tabs-"):
                idx = order.index("--tabs-pill-active-text-color") + 1 if "--tabs-pill-active-text-color" in order else len(order)
            else:
                idx = len(order)
            order.insert(idx, k)
    return order, values

def resolve(token, overlay, base, depth=0):
    if depth > 10:
        return None
    v = overlay.get(token, base.get(token))
    if v is None:
        return None
    v = expand_brand(v)
    if v.startswith("var("):
        m = re.match(r"var\((--[a-z0-9-]+)\)", v, re.I)
        if m:
            return resolve(m.group(1), overlay, base, depth + 1)
    return v

def slim_theme(order, theme_vals, orig_root, root_vals):
    kept_order, kept = [], {}
    for key in order:
        if key in EXPLICIT_REMAPS:
            continue
        theme_decl = theme_vals[key]
        root_decl = root_vals.get(key)
        if root_decl is not None and expand_brand(theme_decl) == expand_brand(root_decl):
            continue
        kept_order.append(key)
        kept[key] = theme_decl
    for key in order:
        if key not in EXPLICIT_REMAPS:
            continue
        intended = resolve(key, theme_vals, orig_root)
        without = resolve(key, kept, root_vals)
        if without != intended:
            kept_order.append(key)
            target = re.match(r"var\((--[a-z0-9-]+)\)", EXPLICIT_REMAPS[key], re.I).group(1)
            if resolve(target, kept, root_vals) == intended:
                kept[key] = EXPLICIT_REMAPS[key]
            else:
                kept[key] = theme_vals[key]
    return kept_order, kept

def format_block(sel, order, values, comment=None):
    lines = []
    if comment:
        lines.append(comment)
    lines.append(f"{sel} {{")
    for key in order:
        lines.append(f"  {key}: {values[key]};")
    lines.append("}")
    return "\n".join(lines)

def main():
    css = SRC.read_text()
    if "overrides only" in css and css.count("[data-theme") >= 3:
        # Already slimmed — refuse to avoid data loss
        print("Input looks already slimmed; pass the full original CSS path.", file=sys.stderr)
        sys.exit(1)

    theme_order, theme_vals, theme_start, theme_end = extract_block(css, r"@theme\s*\{")
    root_order, root_vals, root_start, root_end = extract_block(css, r"/\* Light mode palette \(default\) \*/\s*:root\s*\{")
    dark_order, dark_vals, dark_start, dark_end = extract_block(css, r'/\* Dark theme palette \*/\s*\[data-theme="dark"\]\s*\{')
    ocean_order, ocean_vals, ocean_start, ocean_end = extract_block(css, r'/\* Ocean theme palette \*/\s*\[data-theme="ocean"\]\s*\{')
    rounded_order, rounded_vals, rounded_start, rounded_end = extract_block(css, r'/\* Rounded theme palette \*/\s*\[data-theme="rounded"\]\s*\{')

    between_theme_root = css[theme_end + 1 : root_start]
    between_root_dark = css[root_end + 1 : dark_start]
    between_dark_ocean = css[dark_end + 1 : ocean_start]
    between_ocean_rounded = css[ocean_end + 1 : rounded_start]
    after_rounded = css[rounded_end + 1 :]
    orig_root = dict(root_vals)

    theme_order, theme_vals = apply_base(theme_order, theme_vals)
    root_order, root_vals = apply_base(root_order, root_vals)

    dark_o, dark_v = slim_theme(dark_order, dark_vals, orig_root, root_vals)
    ocean_o, ocean_v = slim_theme(ocean_order, ocean_vals, orig_root, root_vals)
    rounded_o, rounded_v = slim_theme(rounded_order, rounded_vals, orig_root, root_vals)

    header = """/* FlatPack CSS Variables - Tailwind v4 Native Theming
 *
 * Token hierarchy:
 *   1. Brand primitives (--brand-hue, --brand-chroma) — change these to recolor the app
 *   2. Semantic tokens (--color-*, --surface-*, --radius-*, --shadow-*, --duration-*)
 *   3. Component tokens (--button-*, --sidebar-*, …) — defined once; prefer var(--semantic)
 *
 * @theme registers the inventory for Tailwind utilities.
 * :root provides the default light palette + component wiring.
 * [data-theme="…"] overrides only tokens that differ from :root (semantics / intentional component exceptions).
 */

"""
    parts = [
        header,
        format_block("@theme", theme_order, theme_vals),
        between_theme_root.rstrip() + "\n",
        format_block(":root", root_order, root_vals, comment="/* Light mode palette (default) — full semantic + component wiring */"),
        between_root_dark.rstrip() + "\n",
        format_block('[data-theme="dark"]', dark_o, dark_v, comment="/* Dark theme — overrides only (inherits component aliases from :root) */"),
        between_dark_ocean.rstrip() + "\n",
        format_block('[data-theme="ocean"]', ocean_o, ocean_v, comment="/* Ocean theme — overrides only */"),
        between_ocean_rounded.rstrip() + "\n",
        format_block('[data-theme="rounded"]', rounded_o, rounded_v, comment="/* Rounded theme — overrides only */"),
        after_rounded,
    ]
    text = re.sub(r"\n{3,}", "\n\n", "\n".join(parts))
    out = ROOT / "app/assets/stylesheets/flat_pack/variables.css"
    out.write_text(text)
    print(f"Wrote {out} ({len(text.splitlines())} lines)")
    print(f"dark={len(dark_v)} ocean={len(ocean_v)} rounded={len(rounded_v)}")

if __name__ == "__main__":
    main()
