# PR #215 stills — Content component

Captured from the live dummy app. Before is `main` at `50e6a1a9`. After is the PR branch (see git HEAD). Viewport 1440×1100 (themes 1440×900). Kit CSS loaded via `flat_pack/variables` + `flat_pack/application`.

## Primary route: `/demo/text/content`

The route exists on both branches. Main ships unwrapped Tailwind-sized HTML. The PR wraps the same article in `div.fp-content` so bare `p` / `h1` / `ul` take that scale.

| File | Branch | Caption |
|---|---|---|
| `before-content-demo.png` | main | Dummy `/demo/text/content` on main. Per-element type classes (`text-base`, `text-xl`, `sm:text-5xl`). No `.fp-content`. Gem `0.1.184`. |
| `after-content-demo.png` | PR | Same article on the PR, wrapped in `FlatPack::Content::Component`. Bare tags. Display `h1` is 48px, lead 20px, body 16px / 1.75, kicker 16px semibold. Spacing matches main (`mt-2` title, `mt-6` lead, `mt-10` into the body stack). |
| `after-content-lists.png` | PR | Same route, lower page: bare `ul` + `blockquote`. **Before is N/A** on main. |

## Other changed demo: `/themes`

| File | Branch | Caption |
|---|---|---|
| `before-themes.png` | main | `/themes` on main. No Content token section. |
| `after-themes.png` | PR | `/themes#content`. Content tokens: `--content-p-size` → `var(--text-base)`, `--content-h1-size` → `var(--text-4xl)`, `--content-h2-size` → `var(--text-2xl)`. |

## Notes

- Styles are unlayered `.fp-content p`, `.fp-content h1`, and the other tags so WYSIWYG HTML does not need extra classes.
- First `p` before a heading is the kicker. First `p` after `h1` is the lead.
