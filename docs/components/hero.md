# Hero

Renders a full-width landing-page hero section in one of seven layout variants with optional badge, tagline, headline, description, and CTA actions.

## Purpose

Provide a single, opinionated entry point for building page-level hero sections without writing bespoke HTML. Handles responsive layout, background image safe rendering, and URL sanitization internally.

## When to use

- Marketing landing pages that need a prominent first section.
- Application dashboards that open with a key message or call-to-action.
- Any page where a large, structured headline-plus-image block is needed.

Do not use for smaller in-page promotional banners; use `FlatPack::Alert::Component` or `FlatPack::Card::Component` instead.

## Class

`FlatPack::Hero::Component`

## Props

| name | type | default | required | description |
|---|---|---|---|---|
| `variant` | Symbol | `:centered` | no | Layout variant. One of: `:centered`, `:centered_image`, `:screenshot`, `:split_image`, `:angled_image`, `:image_tiles`, `:offset_image`. Invalid values raise `ArgumentError`. |
| `tagline` | String | `nil` | no | Small uppercase label rendered above the headline. |
| `headline` | String | `nil` | no | Primary `<h1>` text. |
| `description` | String | `nil` | no | Supporting paragraph below the headline. |
| `image_url` | String | `nil` | no | Main image URL. Used by `screenshot`, `split_image`, `angled_image`, `offset_image`. Sanitized via `FlatPack::AttributeSanitizer.sanitize_url`. |
| `image_alt` | String | `""` | no | Alt text for the main image. Pass `""` for decorative images. |
| `background_image_url` | String | `nil` | no | Background image URL for `centered_image`. Sanitized. Applied via `style` attribute only after sanitization. |
| `background` | String | `nil` | no | CSS background value applied to the root `<section>`. Accepts any valid CSS — solid colors (`#1e293b`), gradients (`linear-gradient(135deg, #667eea, #764ba2)`), CSS variables (`var(--surface-page-background-color)`). Any `url()` expressions are stripped before rendering. |
| `tiles` | Array | `[]` | no | Array of `{ url:, alt: }` hashes for `image_tiles` (2–4 items shown). Each `url` is sanitized individually. |
| `**system_arguments` | Hash | `{}` | no | Additional HTML attributes forwarded to the root `<section>` element. |

## Slots

| name | required | description |
|---|---|---|
| `actions` | no | CTA button area rendered below the description in all variants. Use `concat render(...)` for multiple buttons. |
| `badge` | no | Optional badge or pill rendered above the tagline. |

Both slots follow the no-`with_` prefix convention. Set via block:

```erb
<%= render FlatPack::Hero::Component.new(variant: :centered, headline: "Hello") do |hero|
  hero.badge { render FlatPack::Badge::Component.new(label: "New") }
  hero.actions do
    concat render(FlatPack::Button::Component.new(label: "Start", href: "#"))
  end
end %>
```

## Variants

| value | description |
|---|---|
| `:centered` | Centered text and actions, no image. |
| `:centered_image` | Centered text over a full-bleed background image with a `bg-black/60` overlay. |
| `:screenshot` | Centered text above a large constrained app screenshot. |
| `:split_image` | Two-column grid: text left, image right. Stacks on mobile. |
| `:angled_image` | Text left, image right with a diagonal polygon clip. Image replaced by a stacked image on mobile. |
| `:image_tiles` | Text left, 2×2 image tile grid right. Stacks on mobile. |
| `:offset_image` | Text left, image partially offset outside the container with `lg:-mr-24`. Stacks on mobile. |

## Example

```erb
<%= render FlatPack::Hero::Component.new(
  variant: :centered,
  tagline: "Introducing FlatPack",
  headline: "Build beautiful interfaces faster.",
  description: "A Rails ViewComponent library with Tailwind CSS."
) do |hero|
  hero.actions do
    concat render(FlatPack::Button::Component.new(label: "Get started", variant: :primary, href: "/docs"))
    concat render(FlatPack::Button::Component.new(label: "Learn more", variant: :outline, href: "/about"))
  end
end %>
```

### Split image with badge

```erb
<%= render FlatPack::Hero::Component.new(
  variant: :split_image,
  tagline: "Modern design",
  headline: "Text left, image right.",
  description: "Stacks gracefully on smaller screens.",
  image_url: "https://example.com/product.jpg",
  image_alt: "Product screenshot"
) do |hero|
  hero.badge { render FlatPack::Badge::Component.new(label: "v2.0") }
  hero.actions do
    concat render(FlatPack::Button::Component.new(label: "View docs", href: "/docs"))
  end
end %>
```

### Image tiles

```erb
<%= render FlatPack::Hero::Component.new(
  variant: :image_tiles,
  headline: "Show off multiple visuals.",
  tiles: [
    { url: "/images/feature1.jpg", alt: "Feature 1" },
    { url: "/images/feature2.jpg", alt: "Feature 2" },
    { url: "/images/feature3.jpg", alt: "Feature 3" },
    { url: "/images/feature4.jpg", alt: "Feature 4" }
  ]
) %>
```

## Accessibility

- Use a single `<h1>` per page; the hero headline fills that semantic role.
- Pass `image_alt: ""` for purely decorative images. This renders an empty `alt` attribute, which instructs screen readers to skip the image.
- The background image in `centered_image` is applied via CSS (`background-image` inline style) and carries no `alt` text, making it presentational by default.
- Buttons and links inside the `actions` slot must have descriptive labels. Avoid generic labels like "Click here".
- Ensure sufficient colour contrast between overlay text and the background for `centered_image`. The built-in `bg-black/60` overlay meets WCAG AA for white text in most cases, but verify with your specific image.

## Dependencies

- `FlatPack::BaseComponent`
- `FlatPack::AttributeSanitizer` — URL sanitization for `image_url`, `background_image_url`, and each tile URL.
- No Stimulus controllers required.
