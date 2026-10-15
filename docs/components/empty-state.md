# Empty State

## Purpose
Invite the person to do the next useful thing when a list, search, or panel has nothing in it yet.

## When to use
Use Empty State when a surface is blank and the person can act: create the first item, clear filters, connect a source. Lead with that action. A quiet icon is the usual mark. Use `media` for one picture that keeps its own shape, or `graphic` when the empty screen is the page and needs a large composition above the title.

## Class
- Primary: `FlatPack::EmptyState::Component`
- Related classes: `FlatPack::Collection::Component`, `FlatPack::Media::Component`, `FlatPack::Shared::IconComponent`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | yes | Heading that names what is missing. |
| `description` | String | `nil` | no | One sentence on what to do next. |
| `icon` | Symbol/String/false | `nil` | no | Kit icon name (`:inbox`, `:search`, or any `IconComponent` name). Pass `false` or omit to skip. Ignored when `graphic` or `media` is set. |
| `icon_variant` | Symbol | `nil` | no | Heroicon weight for `icon`: `:outline`, `:solid`, `:mini`, `:micro`. Omit to use `default_icon_variant`. Requires `icon`. |
| `size` | Symbol | `:md` | no | Density for padding, description, icon, and the gaps: `:sm`, `:md`, `:lg`. Padding and gaps read `--empty-state-*` tokens, which are `calc(var(--space-N) * var(--density))`. |
| `title_size` | Symbol | from `size` | no | Heading step: `:xs`, `:sm`, `:base`, `:lg`, `:xl`, `:xxl`, or `:display`. `:display` uses `.fp-display`. Omit and `:sm` maps to `:base`, `:md` to `:lg`, `:lg` to `:xl`. Not Hero `title_size`. |
| `width` | Symbol | `:md` | no | Max width of the text block: `:sm`, `:md`, `:lg`, or `:full` (`--empty-state-measure-*`). `:md` is `28rem`. `:full` is `max-width: none`. A `media` image uses the same cap. The root does not. |
| `layout` | Symbol | `:wrap` | no | Action arrangement: `:wrap` (wrapping row) or `:stack` (one under the next). Renders `FlatPack::Collection::Component`. Not `:grid`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `item` | slot | no | One action. Repeat it. The items render in a Collection using `layout`. |
| `graphic` | slot | no | Freeform composition above the title. It spans the empty state, so a large hero fits. Not cropped. |
| `media` | component | no | One image via `FlatPack::Media::Component` (`src`, `alt`, `width`, `height`). The image keeps that aspect ratio and is capped by `width:`. |

Pass `graphic` or `media`, not both.

## Width
The root is a block-level flex column. It sets no width and no max-width, so in normal flow it stretches to the full width of its container. Only the description used to be capped (`max-w-md`). `width:` now caps the whole text block, centred in that full-width root. The graphic stays full width of the root so a hero can be wider than the words.

## Variants
- `size:` `:sm`, `:md`, `:lg` for padding and type density.
- `layout:` `:wrap` or `:stack` for the actions.
- `width:` `:sm`, `:md`, `:lg`, `:full` for the text measure.
- `title_size:` including `:display` for a cover heading.

## Example
```erb
<%= render FlatPack::EmptyState::Component.new(
  title: "No projects yet",
  description: "Create a project to group work in one place.",
  icon: :folder,
  icon_variant: :solid,
  width: :md,
  layout: :wrap
) do |state| %>
  <% state.item do %>
    <%= render FlatPack::Button::Component.new(text: "Create project", style: :primary) %>
  <% end %>
<% end %>
```

A picture instead of an icon:

```erb
<% state.media(src: "/images/harbour.jpg", alt: "Harbour at dusk", width: 1280, height: 850) %>
```

A large opening:

```erb
<%= render FlatPack::EmptyState::Component.new(
  title: "Your story starts with a press kit",
  description: "Share news, assets, and stories with journalists.",
  title_size: :display,
  width: :lg
) do |state| %>
  <% state.graphic do %>
    <%# A wide composition. It is not limited to the text measure. %>
  <% end %>
  <% state.item do %>
    <%= render FlatPack::Button::Component.new(text: "Create press kit", style: :primary) %>
  <% end %>
<% end %>
```

## Empty then content
The root is `.fp-empty-state`. It fades and rises a few pixels on `--duration-slow` / `--easing-enter` (`@starting-style`). When the first item arrives, hide the empty panel and show content with `.fp-content-enter` so the swap uses the same motion. Reduced motion snaps with no transform.

Dummy `/demo/empty_state` has a Show empty / Show content toggle, plus icon, image, width, stacked actions, and a hero graphic.

## Accessibility
- Title and description are semantic text. The title is an `h3`.
- Put the next step on a real button in `item`, not only in the description.
- Each `item` is an `<li>` inside the Collection list.
- `media` requires `alt` (pass `""` when the picture is decorative). A decorative `graphic` should be hidden from assistive tech by the caller.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- `FlatPack::Shared::IconComponent` when `icon` is set.
- `FlatPack::Media::Component` when `media` is set.
- `FlatPack::Collection::Component` when there is at least one `item`.
- Kit CSS: `.fp-empty-state`, `.fp-content-enter`, and the `--empty-state-*` tokens (formulas of `--space-*` and `--density`).
