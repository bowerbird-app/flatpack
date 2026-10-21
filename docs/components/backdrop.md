# Backdrop

## Purpose
Put a blurred photo, a tint, and an edge fill behind any content.

## When to use
Use Backdrop when a hero, a page section, a card, a modal, or a full page should sit on a washed photo. The host supplies the `img`, `picture`, or `video`. The host also styles the words and buttons. Do not use Backdrop for the mobile drawer dim (`--drawer-backdrop-color`) or a dialog scrim. Hero keeps its own wash. Carousel keeps its own slides.

## Class
- Primary: `FlatPack::Backdrop::Component`
- Related classes: `FlatPack::SidebarLayout::Component`, `FlatPack::PageLayout::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `**system_arguments` | Hash | `{}` | No | HTML attributes merged into the root. Use `class` for height and layout. The root does not set type, colour, or padding. |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `media` | slot (`with_media`) | No | The host's `img`, `picture`, or `video`. One slot. Omit it and the component renders the content with no photo, tint, or fill. |
| content | block | No | Whatever sits in front of the photo. Markup, a card, a heading, a button. The component does not style it. |

## Variants
None.

## Example

```erb
<%= render FlatPack::Backdrop::Component.new(class: "flex min-h-96 w-full items-end") do |backdrop| %>
  <% backdrop.with_media do %>
    <%= image_tag photo_path, alt: "" %>
  <% end %>

  <div class="p-8">
    <h2>Pack the morning</h2>
  </div>
<% end %>
```

The root fills its container, clips with `overflow: hidden`, and uses `border-radius: inherit`, so a rounded card or section keeps its corner. Set the corner on the container. A decorative photo with no content is `aria-hidden="true"` and ignores pointer events.

`SidebarLayout` and `PageLayout` `background` render this component and fix that one instance to the viewport. See [Sidebar Layout](sidebar_layout.md) and [Page Layout](page_layout.md).

## Accessibility
The photo, tint, and fill are `aria-hidden="true"`. Pass `alt=""` when the photo is decorative, or a real `alt` when the media slot is the only description. Content in the block stays available. A backdrop with no content marks the root `aria-hidden="true"` and does not take clicks. Under `prefers-reduced-transparency: reduce`, or when `filter: blur()` is unavailable, the photo is hidden and the tint becomes solid.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- No Stimulus controller.
- Tokens: `--backdrop-blur` (`40px`), `--backdrop-color` (`transparent`), `--backdrop-filter` (`saturate(1)`), `--backdrop-tint-color` (the page colour), `--backdrop-tint-opacity` (`0.55`, `0.78` on dark). `[data-theme~="rounded"]` sets the edge to `#2f2f2f`, the tint to `#000`, and the opacity to `0.18`. That block follows dark, so `rounded dark` keeps `0.18`.
