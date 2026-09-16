# Dummy stills — Content demo (main vs this branch)

Captured from live dummy apps. Before is `main` at `50e6a1a9` (gem `0.1.184`). After is this branch (gem `0.1.185`). Kit CSS loaded. Light theme.

Viewport **1440×1100** for `/demo/text/content`. Viewport **1440×900** for `/themes`.

| File | Branch | Route | Caption |
|---|---|---|---|
| `before-text-content.png` | main | `/demo/text/content` | Page from the Content title. Tailwind classes on each tag. No `.fp-content`. |
| `after-text-content.png` | this branch | `/demo/text/content` | Same viewport from the Content title. Param table plus the article start inside `FlatPack::Content::Component`. |
| `before-text-content-article.png` | main | `/demo/text/content` | Same viewport, scrolled to the long-form card (`Publish Faster` / `A Mastered Workflow`). |
| `after-text-content-article.png` | this branch | `/demo/text/content` | Same viewport, scrolled to the long-form card. Bare tags in `.fp-content`. Computed: kicker/body 18px, lead 24px, h1 48px. |
| `after-text-content-lists.png` | this branch | `/demo/text/content` | Lists and quote section (new on this branch). No main equivalent. |
| `before-themes.png` | main | `/themes#comments` | Token groups at Comments. No Content group. |
| `after-themes.png` | this branch | `/themes#content` | Content tokens (`--content-p-size` → `var(--text-lg)`, `--content-h1-size` → `var(--text-5xl)`). |

Copies also live under `/opt/cursor/artifacts/pr215/`.
