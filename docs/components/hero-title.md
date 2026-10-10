# Hero Title

## Purpose
Render a standalone cover headline: fluid jumbo type with balanced wrapping, tunable size steps, and a semantic heading tag.

## When to use
Use Hero Title for a big cover line on its own — a press kit, a landing splash, or any page that needs the display scale without a full Hero block.

- Use `FlatPack::Hero::Component` when the headline sits in a landing hero with tagline, body, image, and actions. Hero `size: :display` (or `title_size:`) renders this component for you.
- Use `FlatPack::PageTitle::Component` for in-app page headings (`font-bold`, `--page-title-h*-size`). Pass `size: :display` when a page heading should be cover type; that path also renders Hero Title.
- Do not use Hero Title for section headings inside a page. Use `FlatPack::SectionTitle::Component`.

## Class
- Primary: `FlatPack::HeroTitle::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | conditional | Headline copy. Required unless the same string is passed as block content. |
| `size` | Symbol, String | `:xl` | no | Fluid cover step. One of `:md`, `:lg`, `:xl`, `:xxl`. `:xl` is today's `--display-size` (`clamp` from `--display-size-min` / 48px to `--display-size-max` / 88px, preferred `1rem + 5vw`). Invalid values raise `ArgumentError`. |
| `level` | Symbol, String | `:h1` | no | Semantic heading tag. One of `:h1`, `:h2`, `:h3`, `:h4`, `:h5`, `:h6`. Invalid values raise `ArgumentError`. |
| `align` | Symbol, String | `nil` | no | Optional text alignment. One of `:left`, `:center`. Omit to inherit from the parent. Invalid values raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the heading tag (`class`, `id`, `style`, and the rest). |

## Slots
None. Pass copy as `text:` or as the component block.

## Variants
- Size: `:md` (36px → 60px), `:lg` (48px → 72px), `:xl` (48px → 88px, default, same as `--display-size`), `:xxl` (48px → 96px).
- Level: `:h1`–`:h6`.
- Align: omit, `:left`, `:center`.

## Example
```erb
<%= render FlatPack::HeroTitle::Component.new(
  text: "A press kit for the Northlight collection"
) %>
```

### Smaller and larger steps

```erb
<%= render FlatPack::HeroTitle::Component.new(
  text: "Northlight",
  size: :md
) %>

<%= render FlatPack::HeroTitle::Component.new(
  text: "Northlight",
  size: :xxl,
  level: :h2,
  align: :center
) %>
```

## Accessibility
- Default tag is `<h1>`. Pass `level:` so the heading rank matches the page outline. One `<h1>` per page.
- Copy is the accessible name. Do not hide the text or replace it with a decorative image.

## Dependencies
- `FlatPack::BaseComponent`
- Kit tokens `--hero-title-*-size` / `-min` / `-max`, plus `--display-weight`, `--display-tracking`, and `--display-leading`.
- Ink is `text-[var(--surface-content-color)]` so light and dark islands follow the surface. Pass another `text-*` class to override (Hero overlay ink does this).
- Unlayered `.fp-hero-title` and `.fp-display` so Tailwind preflight cannot collapse heading size.
- No Stimulus controllers required.
