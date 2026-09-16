# PR #215 stills — Content component

Captured from the live dummy app. Before is `main` at `50e6a1a9` (port 3001). After is `cursor/content-component-type-scale-8523` at `6e01fd92` (port 3000). Viewport 1440×1100 (themes 1440×900). Kit CSS loaded via `flat_pack/variables` + `flat_pack/application`.

## Primary route: `/demo/text/content`

The route exists on both branches. Main ships unwrapped Tailwind-sized HTML. The PR wraps the article in `FlatPack::Content::Component` (`.fp-content`) and adds the method table plus a lists/quote example.

| File | Branch | Caption |
|---|---|---|
| `before-content-demo.png` | main | Dummy `/demo/text/content` on main. Long-form card uses per-element type classes (`text-base`, `text-xl`, `sm:text-5xl`). No `.fp-content` wrapper. Gem `0.1.184`. |
| `after-content-demo.png` | PR | Same route on the PR. Article is inside `.fp-content`. Kicker uses `.fp-content-kicker`, lead uses `.fp-content-lead`, body `p` is 18px (`--content-p-size` → `--text-lg`). Method table sits above the card. Gem `0.1.185`. |
| `after-content-lists.png` | PR | Same route, lower on the page. New “Lists and a quote” card (plain `ul` + `blockquote`) and the page’s Content token table. **Before is N/A** — main has no lists/quote section and no `--content-*` table on this page. |

## Other changed demo: `/themes`

The PR adds a **Content** token group (`--content-kicker-size` through `--content-h6-size`) to the theme variable catalog.

| File | Branch | Caption |
|---|---|---|
| `before-themes.png` | main | Dummy `/themes` on main, top of the catalog. No Content token section. Brand primitives start the grouped tables. |
| `after-themes.png` | PR | Dummy `/themes#content` on the PR. New Content table: `--content-p-size` → `var(--text-lg)` (18px at a 16px root), plus kicker, lead, and heading aliases. Quote tokens follow. |

## Notes

- Public dummy `/demo` and `/themes` rendered without Postgres.
- Tailwind host CSS was not committed. Kit `.fp-content` rules come from `flat_pack/application`.
- No other dummy routes besides `/demo/text/content` and `/themes` were visually changed by this PR. Sidebar copy for Content is visible on the same Content demo stills.
